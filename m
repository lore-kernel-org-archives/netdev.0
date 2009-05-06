From: Wolfgang Denk <wd@denx.de>
Subject: Re: [PATCH 02/12] fs_enet: Add MPC5121 FEC support.
Date: Thu, 07 May 2009 00:41:34 +0200
Message-ID: <20090506224134.83F1583420E8@gemini.denx.de>
References: <1241640919-4650-1-git-send-email-wd@denx.de> <1241640919-4650-3-git-send-email-wd@denx.de> <fa686aa40905061333q29c263c8p24856c048e30f4d0@mail.gmail.com> <20090506220119.7322783420E8@gemini.denx.de> <fa686aa40905061529u11b231afle3b5bb10a2334ad0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: linuxppc-dev@ozlabs.org, John Rigby <jrigby@freescale.com>,
	Piotr Ziecik <kosmo@semihalf.com>, netdev@vger.kernel.org,
	John Rigby <jcrigby@gmail.com>, Detlev Zundel <dzu@denx.de>
To: Grant Likely <grant.likely@secretlab.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.10]:35751 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753164AbZEFWlg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2009 18:41:36 -0400
In-reply-to: <fa686aa40905061529u11b231afle3b5bb10a2334ad0@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Grant,

In message <fa686aa40905061529u11b231afle3b5bb10a2334ad0@mail.gmail.com> you wrote:
>
> > Agreed that it's ugly, but duplicatio9ng the code would have been even
> > worse. I don't think that it has multiplatform - at least not as long
> > as you don't ask for one image that runs on 83xx and on 512x.
> 
> Actually, I *am* asking for one image that runs on 83xx, 52xx and
> 521x.  I already can and do build and test a single image which boots
> on all my 52xx boards, on my 8349 board, and on my G4 Mac.

He. I was afraid you'd say that ;-)

In this case I need a helping hand as I can't figure out how to make
this work. Any suggestions?

Best regards,

Wolfgang Denk

-- 
DENX Software Engineering GmbH,     MD: Wolfgang Denk & Detlev Zundel
HRB 165235 Munich, Office: Kirchenstr.5, D-82194 Groebenzell, Germany
Phone: (+49)-8142-66989-10 Fax: (+49)-8142-66989-80 Email: wd@denx.de
"Here's a fish hangs in the net like a poor man's right in  the  law.
'Twill hardly come out."     - Shakespeare, Pericles, Act II, Scene 1
