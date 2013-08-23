From: Daniel Mack <zonque@gmail.com>
Subject: Re: [PATCH v6 0/5] cpsw: support for control module register
Date: Fri, 23 Aug 2013 21:41:32 +0200
Message-ID: <5217BAEC.8060602@gmail.com>
References: <1377286330-29663-1-git-send-email-zonque@gmail.com> <5217BA50.6050609@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bcousson@baylibre.com, nsekhar@ti.com,
	sergei.shtylyov@cogentembedded.com, davem@davemloft.net,
	ujhelyi.m@gmail.com, vaibhav.bedia@ti.com, d-gerlach@ti.com,
	linux-arm-kernel@lists.infradead.org, linux-omap@vger.kernel.org,
	devicetree@vger.kernel.org
To: Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f54.google.com ([74.125.83.54]:62788 "EHLO
	mail-ee0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754474Ab3HWTlg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Aug 2013 15:41:36 -0400
In-Reply-To: <5217BA50.6050609@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 23.08.2013 21:38, Mugunthan V N wrote:
> On Saturday 24 August 2013 01:02 AM, Daniel Mack wrote:

>> v5 -> v6:
>> 	* re-add code to fail if 3rd memory region is given but invalid
>> 	* added Mugunthan's ack on all patches except the one that adds
>> 	  ti,am3352-cpsw
>> 	* remove parens around integer constants
> I am also in your favour of adding ti,am3352-cpsw, but lets get other
> comment. You can add my ack to that patch also if you are submitting
> another version.

I don't think I'll have a chance to do that before I'm AFK for a while :)

That's also the only reason why I sent a v6 already. I would have
normally waited for that discussion to settle of course.

But as I said: I'd be fine if anyone adds another patch on top or amends
mine.


Thanks for the reviews again, everyone!


Daniel
