From: "Brian F. G. Bidulock" <bidulock@openss7.org>
Subject: Re: [RFC/PATCH 1/2] in-kernel sockets API
Date: Tue, 13 Jun 2006 15:40:31 -0600
Message-ID: <20060613154031.A6276@openss7.org>
References: <1150156562.19929.32.camel@w-sridhar2.beaverton.ibm.com> <20060613140716.6af45bec@localhost.localdomain> <20060613052215.B27858@openss7.org> <448F2A49.5020809@google.com>
Reply-To: bidulock@openss7.org
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@osdl.org>,
	Sridhar Samudrala <sri@us.ibm.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw.openss7.com ([142.179.199.224]:41648 "EHLO gw.openss7.com")
	by vger.kernel.org with ESMTP id S932329AbWFMVkd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jun 2006 17:40:33 -0400
To: Daniel Phillips <phillips@google.com>
Content-Disposition: inline
In-Reply-To: <448F2A49.5020809@google.com>; from phillips@google.com on Tue, Jun 13, 2006 at 02:12:41PM -0700
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Daniel,

On Tue, 13 Jun 2006, Daniel Phillips wrote:
> 
> This has the makings of a nice stable internal kernel api.  Why do we want
> to provide this nice stable internal api to proprietary modules?

Why not?  Not all non-GPL modules are proprietary.  Do we lose
something by making a nice stable api available to non-derived
modules?
