From: "Adolfo R. Brandes" <arbrandes@gmail.com>
Subject: Re: forcedeth: MAC-address reversed on resume from suspend
Date: Sun, 6 Jan 2008 19:49:49 -0200
Message-ID: <b4292e150801061349v3b54ffc0vfed75dbcb83daf9b@mail.gmail.com>
References: <477BFC71.7090002@coderworld.net>
	 <20080102214843.GA19224@rhlx01.hs-esslingen.de>
	 <20080102234209.GA10831@does.not.exist>
	 <20080104034357.GA2113@atjola.homenet>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Adrian Bunk" <bunk@kernel.org>, "Andreas Mohr" <andi@lisas.de>,
	"Richard Jonsson" <richie@coderworld.net>,
	linux-kernel@vger.kernel.org, "Ayaz Abdulla" <aabdulla@nvidia.com>,
	jgarzik@pobox.com, netdev@vger.kernel.org
To: "=?ISO-8859-1?Q?Bj=F6rn_Steinbrink?=" <B.Steinbrink@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.247]:54298 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753247AbYAFVtu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Jan 2008 16:49:50 -0500
Received: by an-out-0708.google.com with SMTP id d31so1319398and.103
        for <netdev@vger.kernel.org>; Sun, 06 Jan 2008 13:49:49 -0800 (PST)
In-Reply-To: <20080104034357.GA2113@atjola.homenet>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 I have this forcedeth MAC address reversal problem when suspending
on 2 distinct boxes.  I can confirm Steinbrink's patch fixes the
problem on only one of them:

00:0a.0 Bridge: nVidia Corporation CK804 Ethernet Controller (rev f3)

 On the other one the problem persists:

00:14.0 Bridge: nVidia Corporation MCP51 Ethernet Controller (rev a1)

Thanks,
Adolfo
