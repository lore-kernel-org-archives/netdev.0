From: Martin Lucina <mato@kotelna.sk>
Subject: Re: sky2 hangs, hw csum errors with 2.6.18
Date: Tue, 3 Oct 2006 21:15:47 +0200
Message-ID: <20061003191546.GQ14180@dezo.moloch.sk>
References: <20060922112442.GB4161@dezo.moloch.sk> <20060922095642.5acf4ac9@dxpl.pdx.osdl.net> <20060922182924.GE4161@dezo.moloch.sk> <20060922113152.02874cbc@localhost.localdomain> <20060922183812.GF4161@dezo.moloch.sk> <20060922115008.5060c599@localhost.localdomain> <20061003182119.GM14180@dezo.moloch.sk> <20061003113538.4c3fe57d@freekitty> <20061003183948.GO14180@dezo.moloch.sk> <20061003120355.0730097a@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from chrocht.moloch.sk ([62.176.169.44]:55514 "EHLO mail.moloch.sk")
	by vger.kernel.org with ESMTP id S1030485AbWJCTPt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Oct 2006 15:15:49 -0400
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20061003120355.0730097a@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Possibly related, could the TX hangs be due to extreme load / no free
memory on the machine?  I just realised that my application appears to
be loading the machine to the max... (i.e. all 2GB RAM used + another
couple GB in swap)

-mato
