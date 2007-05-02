From: Kim Phillips <kim.phillips@freescale.com>
Subject: Re: patches for 2.6.22
Date: Wed, 2 May 2007 09:19:01 -0500
Message-ID: <20070502091901.4c37ecbb.kim.phillips@freescale.com>
References: <17969.56735.644629.328360@cargo.ozlabs.ibm.com>
	<20070430145119.6713490e.kim.phillips@freescale.com>
	<42664CF1-75AF-4343-BC50-870D3614C683@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: paulus@samba.org, linuxppc-dev@ozlabs.org, netdev@vger.kernel.org,
	jeff@garzik.org
To: Kumar Gala <galak@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw01.freescale.net ([192.88.165.102]:50164 "EHLO
	de01egw01.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S2993225AbXEBOTQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 May 2007 10:19:16 -0400
In-Reply-To: <42664CF1-75AF-4343-BC50-870D3614C683@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2 May 2007 09:12:36 -0500
Kumar Gala <galak@kernel.crashing.org> wrote:

> 
> I'll pull patches 1, 3, 4 and wait on the dts changes until you sort  
> of the ucc driver issues with Jeff.

sounds good.  I was waiting for the get_property -> of_get_propery
patches for ucc_geth before I submitted the follow-on patch to change
interface-type and remove max-speed.  It's out now, so I can proceed.

Kim
