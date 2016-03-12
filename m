From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net v3.16]r8169:  Not enable/disable bus mastering when
 is enabled on BIOS
Date: Sat, 12 Mar 2016 13:15:17 +0100
Message-ID: <20160312121517.GA17107@electric-eye.fr.zoreil.com>
References: <1457764426-6578-1-git-send-email-asd@marian1000.go.ro>
 <20160312094401.GA15947@electric-eye.fr.zoreil.com>
 <20160312124828.07e467a1@192-168-0-108.rdsnet.ro>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Corcodel Marian <asd@marian1000.go.ro>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:41642 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750954AbcCLMPU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Mar 2016 07:15:20 -0500
Content-Disposition: inline
In-Reply-To: <20160312124828.07e467a1@192-168-0-108.rdsnet.ro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Corcodel Marian <asd@marian1000.go.ro> :
[...]
> For mee this patch is very important , decrease time to autonegociation
> and start nic on full speed alltimes.

Really ? The commit message did not tell much about it.

How much did time decrease ? How did you measure it ? 

Against which chipset(s) ?

On which motherboard ?

How does it behave on current kernel ?

How many different patches are you testing at the same time ?

Who was able to reproduce it ?

How do you explain it ?

-- 
Ueimor
