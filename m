From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 0/6] mvneta: SGMII-based in-band link status signaling
Date: Thu, 26 Mar 2015 10:13:35 -0700
Message-ID: <55143E3F.9080501@gmail.com>
References: <55142C31.5050504@list.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Rami Rosen <rosenr@marvell.com>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
To: Stas Sergeev <stsp@list.ru>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:35459 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752272AbbCZROV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Mar 2015 13:14:21 -0400
Received: by pdbop1 with SMTP id op1so68640652pdb.2
        for <netdev@vger.kernel.org>; Thu, 26 Mar 2015 10:14:21 -0700 (PDT)
In-Reply-To: <55142C31.5050504@list.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On 26/03/15 08:56, Stas Sergeev wrote:
> Hello.
> 
> The following patches are needed when mvneta is used
> in SGMII mode without MDIO.

Would you mind using scripts/get_maintainer.pl such that the relevant
people who have touched this code in the past can be CC'd?

Your patches are barely readable, let alone that you have provided
little to explanation as to why you are making such invasive changes.
-- 
Florian
