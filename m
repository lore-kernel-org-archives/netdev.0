From: Pekka J Enberg <penberg@cs.Helsinki.FI>
Subject: Re: [PATCH 3/3] ipg: plug leaks in the error path of ipg_nic_open
Date: Tue, 2 May 2006 09:45:20 +0300 (EEST)
Message-ID: <Pine.LNX.4.58.0605020945010.4066@sbz-30.cs.Helsinki.FI>
References: <84144f020604280358ie9990c7h399f4a5588e575f8@mail.gmail.com>
 <20060428113755.GA7419@fargo> <Pine.LNX.4.58.0604281458110.19801@sbz-30.cs.Helsinki.FI>
 <1146306567.1642.3.camel@localhost> <20060429122119.GA22160@fargo>
 <1146342905.11271.3.camel@localhost> <1146389171.11524.1.camel@localhost>
 <44554ADE.8030200@cantab.net> <4455F1D8.5030102@cantab.net>
 <1146506939.23931.2.camel@localhost> <20060501231206.GD7419@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: David Vrabel <dvrabel@cantab.net>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, david@pleyades.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:13268 "EHLO
	mail.cs.helsinki.fi") by vger.kernel.org with ESMTP id S932405AbWEBGpW
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 May 2006 02:45:22 -0400
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20060501231206.GD7419@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2 May 2006, Francois Romieu wrote:
> Added ipg_{rx/tx}_clear() to factor out some code.
> 
> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>

Applied. Thanks!

			Pekka
