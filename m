From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net v3.16]r8169:  Not enable/disable bus mastering when
 is enabled on BIOS
Date: Sat, 12 Mar 2016 10:44:01 +0100
Message-ID: <20160312094401.GA15947@electric-eye.fr.zoreil.com>
References: <1457764426-6578-1-git-send-email-asd@marian1000.go.ro>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Corcodel Marian <asd@marian1000.go.ro>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:41496 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751305AbcCLJoJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Mar 2016 04:44:09 -0500
Content-Disposition: inline
In-Reply-To: <1457764426-6578-1-git-send-email-asd@marian1000.go.ro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Corcodel Marian <asd@marian1000.go.ro> :
>  This patch not enable/disable bus mastering when is enabled on BIOS..

It bloats the driver without any benefit.

-- 
Ueimor
