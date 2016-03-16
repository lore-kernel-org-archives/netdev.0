From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH] qmi_wwan: Added support for Gemalto's Cinterion PHxx WWAN interface
Date: Wed, 16 Mar 2016 09:37:49 +0100
Message-ID: <87lh5iq0ma.fsf@nemi.mork.no>
References: <1978E4F2CF12DD4A899FA7487323EB1101083683C0@A1GTOEMBXV004.gto.a3c.atos.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev\@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-usb\@vger.kernel.org" <linux-usb@vger.kernel.org>
To: Schemmel Hans-Christoph <Hans-Christoph.Schemmel@gemalto.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:36155 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934980AbcCPIiV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Mar 2016 04:38:21 -0400
In-Reply-To: <1978E4F2CF12DD4A899FA7487323EB1101083683C0@A1GTOEMBXV004.gto.a3c.atos.net>
	(Schemmel Hans-Christoph's message of "Wed, 16 Mar 2016 08:31:28
	+0000")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Schemmel Hans-Christoph <Hans-Christoph.Schemmel@gemalto.com> writes:

> +	{QMI_FIXED_INTF(0x1e2d, 0x0082, 4)},	/* Cinterion PHxx,PXxx (2
> RmNet) */

That's broken.  Sorry.  You'll have to figure out some way submit this
in a form that can be applied using "git am".

There are some hints in
https://www.kernel.org/doc/Documentation/email-clients.txt



Bj=C3=B8rn
