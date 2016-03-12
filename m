From: Corcodel Marian <asd@marian1000.go.ro>
Subject: Re: [PATCH net v3.16]r8169:  Not enable/disable bus mastering when
 is enabled on BIOS
Date: Sat, 12 Mar 2016 12:48:28 +0200
Message-ID: <20160312124828.07e467a1@192-168-0-108.rdsnet.ro>
References: <1457764426-6578-1-git-send-email-asd@marian1000.go.ro>
	<20160312094401.GA15947@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 5-14-228-122.residential.rdsnet.ro ([5.14.228.122]:60522 "EHLO
	marian1000.go.ro" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751833AbcCLLKb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Mar 2016 06:10:31 -0500
In-Reply-To: <20160312094401.GA15947@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 12 Mar 2016 10:44:01 +0100
Francois Romieu <romieu@fr.zoreil.com> wrote:

> Corcodel Marian <asd@marian1000.go.ro> :
> >  This patch not enable/disable bus mastering when is enabled on
> > BIOS..
> 
> It bloats the driver without any benefit.
> 

For mee this patch is very important , decrease time to autonegociation
and start nic on full speed alltimes.
