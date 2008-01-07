From: "Adolfo R. Brandes" <arbrandes@gmail.com>
Subject: Re: forcedeth: MAC-address reversed on resume from suspend
Date: Mon, 7 Jan 2008 09:02:23 -0300
Message-ID: <b4292e150801070402m14221e9fh6b965a5932f78a4c@mail.gmail.com>
References: <477BFC71.7090002@coderworld.net>
	 <20080102214843.GA19224@rhlx01.hs-esslingen.de>
	 <20080102234209.GA10831@does.not.exist>
	 <20080104034357.GA2113@atjola.homenet>
	 <b4292e150801061349v3b54ffc0vfed75dbcb83daf9b@mail.gmail.com>
	 <20080107014638.GA4170@atjola.homenet>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Adrian Bunk" <bunk@kernel.org>, "Andreas Mohr" <andi@lisas.de>,
	"Richard Jonsson" <richie@coderworld.net>,
	linux-kernel@vger.kernel.org, "Ayaz Abdulla" <aabdulla@nvidia.com>,
	jgarzik@pobox.com, netdev@vger.kernel.org
To: "=?ISO-8859-1?Q?Bj=F6rn_Steinbrink?=" <B.Steinbrink@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.243]:37531 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754890AbYAGMC0 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jan 2008 07:02:26 -0500
Received: by an-out-0708.google.com with SMTP id d31so1366404and.103
        for <netdev@vger.kernel.org>; Mon, 07 Jan 2008 04:02:23 -0800 (PST)
In-Reply-To: <20080107014638.GA4170@atjola.homenet>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Jan 6, 2008 10:46 PM, Bj=F6rn Steinbrink <B.Steinbrink@gmx.de> wrote=
:
> Any chance that you applied the patch on your modified sources and di=
dn't get it right?

  It is perfectly possible that I messed something up, although I
double checked what I was doing on the MCP51.  However, on that board
(an Asus M2NPV-VM) I'm running the 2.6.22-based Ubuntu Gutsy default
kernel with a recompiled forcedeth, as opposed to a vanilla 2.6.24-rc6
on the CK804, where your patch worked.  It may be that the different
kernel is throwing the patch off somehow.

  Later on today I'm going to try the MCP51 with the same build of
2.6.24-rc6 (built on a .config from the Ubuntu Hardy development
kernel) I'm running on the CK804, and post results.

Adolfo
