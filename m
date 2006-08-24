From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH 1/4] Try 2: Add wireless statistics to d80211
Date: Thu, 24 Aug 2006 09:39:52 -0500
Message-ID: <44EDBA38.4020109@lwfinger.net>
References: <44ED16AB.2080306@lwfinger.net> <20060824135934.4df0b1ba@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Linville <linville@tuxdriver.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc12.worldnet.att.net ([204.127.131.116]:44542 "EHLO
	mtiwmhc12.worldnet.att.net") by vger.kernel.org with ESMTP
	id S932068AbWHXOkL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Aug 2006 10:40:11 -0400
To: Jiri Benc <jbenc@suse.cz>
In-Reply-To: <20060824135934.4df0b1ba@griffin.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jiri Benc wrote:
> On Wed, 23 Aug 2006 22:02:03 -0500, Larry Finger wrote:
>> This patch modifies d80211 to add wireless statistics.
>> +	/* This is maximum value of rssi reported by this interface
>> +	 */
>> +	int maxssi;
> 
> Device, not interface. And please do not put */ to a new line.

Noted on the first part, but I would like a clarification regarding style. I put the */ on the 
second line to match the rest of that section. Should a patch try to keep the local style in that 
part of the code, or change it to a some other standard?

Larry

