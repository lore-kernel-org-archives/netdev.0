From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: Re: [PATCH 1/9] bnx2x: remove a few trivial macros
Date: Wed, 21 Jan 2009 09:14:53 +0200
Message-ID: <1232522093.29087.9.camel@lb-tlvb-eliezer>
References: <1232517046.9701.19.camel@brick>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-netdev <netdev@vger.kernel.org>
To: "Harvey Harrison" <harvey.harrison@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4583 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762588AbZAUHPz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Jan 2009 02:15:55 -0500
In-Reply-To: <1232517046.9701.19.camel@brick>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2009-01-20 at 21:50 -0800, Harvey Harrison wrote:
> Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
> ---
> Eilon, after this series, sparse with endian-checking at least gets through a
> compile without hitting too many errors, patch 9 is a functional change
> and may have exposed an endian bug in the driver....but I had to get through
> the other 8 to see it ;-)
> 
Wooh!!! Harvey - thanks for all the hard work!

I will review it carefully and start regression tests on few different
platforms to verify this fix. Stay tuned.

Thanks!
Eilon


