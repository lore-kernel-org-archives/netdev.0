From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: Re: [PATCH 00/39] merge request for WiMAX kernel stack and i2400m driver v2
Date: Thu, 27 Nov 2008 08:51:56 -0800
Message-ID: <200811270851.56450.inaky@linux.intel.com>
References: <cover.1227691434.git.inaky@linux.intel.com> <1227783281.3809.78.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([143.182.124.22]:51733 "EHLO
	azsmga101.ch.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754509AbYK0Qwh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Nov 2008 11:52:37 -0500
In-Reply-To: <1227783281.3809.78.camel@johannes.berg>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi There

On Thursday 27 November 2008, Johannes Berg wrote:
> Hi,
>
> Thanks for this work. I don't personally have much of an interest in
> wimax, so I don't really care what you do, so take things I have said
> and will say with a grain of salt. It's not my intention to say "you've
> done it all wrong", but more to offer observations on how these things
> were done in wifi and how it went all wrong there, requiring a complete
> rewrite recently.

Thanks, I really appreciate the level of review (from you, Patrik and Thomas).

Many of the comments you guys have are solved by documenting why things were
done, others require work, others are remnants that I missed to clean up. 

It's Thanksgiving weekend here in the US, so I most probably will wait for
Monday to address all your guys concerns -- just sending this so you don't
think I don't care :) I do.

-- 
Inaky
