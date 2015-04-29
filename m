From: Prashant Sreedharan <prashant@broadcom.com>
Subject: Re: [Problem] broadcom tg3 network driver disconnects under high
 load
Date: Wed, 29 Apr 2015 11:55:16 -0700
Message-ID: <1430333716.26841.34.camel@prashant>
References: <CAGNmLEMbyR6-1WSyPRZQhLanH_UB7xb5cVVQ9N625bvdhbA6MA@mail.gmail.com>
	 <1429908991.3920.2.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
	 <CAGNmLEMB-hpG_TW3qQGbiHM2Vfd30P=D5H3_ioeY56+iKt14hA@mail.gmail.com>
	 <1430244665.6888.26.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
	 <1430247712.26841.18.camel@prashant>
	 <CAGNmLEOJxarDZxmoXQfruPQ3RP89=h_zOTfBw-Fzq+Vizg315g@mail.gmail.com>
	 <1430253781.26841.21.camel@prashant>
	 <CAGNmLEO31=1JR+fPcsiwSgcKpb2e=w3VNEG8W4J7=i8Lud-5Ng@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Michael Chan <mchan@broadcom.com>, <sanjeevb@broadcom.com>,
	<netdev@vger.kernel.org>
To: Toan Pham <tpham3783@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw2-out.broadcom.com ([216.31.210.63]:46550 "EHLO
	mail-gw2-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751155AbbD2Tkn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2015 15:40:43 -0400
In-Reply-To: <CAGNmLEO31=1JR+fPcsiwSgcKpb2e=w3VNEG8W4J7=i8Lud-5Ng@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-04-29 at 13:34 -0400, Toan Pham wrote:
> Prashant,
> 
> Unfortunately, I ran the same test 3 times with the new patch and all
> of them failed.
> Attached file is the dmesg log, after the Watchdog had timed out, and
> tried to restart the NIC.
> Feel free to let me know if you would like to try anything else.  Thanks
Toan thanks for result, so this looks to be a different problem. Sanjeev
is setting up repo environment similar to yours to capture a pcie trace.
Will keep you posted.  
