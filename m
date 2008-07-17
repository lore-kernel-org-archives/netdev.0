From: Jie Yang <Jie.Yang@Atheros.com>
Subject: RE: [PATCH net-next] atl1e: Atheros L1E Gigabit Ethernet driver
Date: Thu, 17 Jul 2008 10:47:07 +0800
Message-ID: <72981EBCFD196144B7C6999B9FC34A9A3EE613106D@SHEXMB-01.global.atheros.com>
References: <72981EBCFD196144B7C6999B9FC34A9A3EE60E9F58@SHEXMB-01.global.atheros.com>
	<20080715211514.25848d8a@extreme>
	<72981EBCFD196144B7C6999B9FC34A9A3EE60EA59C@SHEXMB-01.global.atheros.com>
	<20080716085329.03e97b2a@extreme> <adafxq9bxbr.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	"jeff@garzik.org" <jeff@garzik.org>,
	David Miller <davem@davemloft.net>,
	"jcliburn@gmail.com" <jcliburn@gmail.com>,
	"parag.warudkar@gmail.com" <parag.warudkar@gmail.com>,
	Willy Tarreau <w@1wt.eu>,
	"oliver.schuster@schweigstill.de" <oliver.schuster@schweigstill.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 175.212.dsnet ([203.110.175.212]:18613 "EHLO mail.atheros.com"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754105AbYGQCrK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jul 2008 22:47:10 -0400
In-Reply-To: <adafxq9bxbr.fsf@cisco.com>
Content-Language: zh-CN
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday, July 17, 2008 12:36 AM
Roland Dreier <rdreier@cisco.com> wrote:
>
>  > Output of checkpatch (scripts/checkpatch.pl in kernel source).
>  > Personally, I am not a whitespace bigot, and don't think
> > all the warnings in checkpatch have to be fixed.
>  >
>  > ----------
>  > ERROR: patch seems to be corrupt (line wrapped?)  > #121:
> FILE: drivers/net/atl1e/atl1e.h:9:
>  > ree
>  >
>  > WARNING: space prohibited between function name and open
> parenthesis '('
>  > #212: FILE: drivers/net/atl1e/atl1e.h:97:
>  > +       _tpd =3D (((_vlan) << (4)) | (((_vlan) >> 13) & 7) |\
>
> It's kind of pointless to run checkpatch on a corrupted patch
> (the email was quoted-printable and you didn't decode it back
> to text).  Of course it's also better to send non-mangled patches.
>
>  - R.
>

Hi, Roland
        I used outlook to send these patches, can you give me some
aderise on how to send non-mangled patches.

Best wishes
jie
