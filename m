From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH netdev-2.6#upstream] net: au1000_eth: PHY framework conversion
Date: Sun, 11 Jun 2006 23:19:16 -0400
Message-ID: <448CDD34.50502@pobox.com>
References: <E1Fli0i-0006o2-Tb@fencepost.gnu.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-mips@linux-mips.org,
	ppopov@embeddedalley.com, sshtylyov@ru.mvista.com,
	ralf@linux-mips.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:11648 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1751147AbWFLDT0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Jun 2006 23:19:26 -0400
To: Herbert Valerio Riedel <hvr@gnu.org>
In-Reply-To: <E1Fli0i-0006o2-Tb@fencepost.gnu.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Valerio Riedel wrote:
> convert au1000_eth driver to use PHY framework and garbage collected
> functions and identifiers that became unused/obsolete in the process
> 
> Signed-off-by: Herbert Valerio Riedel <hvr@gnu.org>

applied


