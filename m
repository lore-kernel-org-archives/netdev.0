From: Steven Hayter <steven@hayter.me.uk>
Subject: Re: Block Http
Date: Sun, 14 May 2006 01:17:08 +0100
Message-ID: <44667704.1000204@hayter.me.uk>
References: <4465AEFB.2080905@rocsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 85.189.5.98 ([85.189.5.98]:43729 "EHLO zombie.undead")
	by vger.kernel.org with ESMTP id S964821AbWENARf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 May 2006 20:17:35 -0400
To: varun <varun@rocsys.com>
In-Reply-To: <4465AEFB.2080905@rocsys.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

varun wrote:
 > Can anyone suggest me a way in which i can stop http downloads
 > but not http traffic.

First point, your on the wrong mailing list for this type of inquiry. 
Second, you might want to look at a Squid proxy, and mime-type 
filtering, check there documentation and users mailing list.

http://www.squid-cache.org/
