From: "Brian F. G. Bidulock" <bidulock@openss7.org>
Subject: Re: [RFC/PATCH 1/2] in-kernel sockets API
Date: Wed, 14 Jun 2006 12:03:02 -0600
Message-ID: <20060614120302.A24700@openss7.org>
References: <1150156562.19929.32.camel@w-sridhar2.beaverton.ibm.com> <20060613140716.6af45bec@localhost.localdomain> <20060613052215.B27858@openss7.org> <448F2A49.5020809@google.com> <20060614133022.GU11863@sunbeam.de.gnumonks.org> <44904C08.6020307@google.com>
Reply-To: bidulock@openss7.org
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Harald Welte <laforge@gnumonks.org>,
	Stephen Hemminger <shemminger@osdl.org>,
	Sridhar Samudrala <sri@us.ibm.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw.openss7.com ([142.179.199.224]:52157 "EHLO gw.openss7.com")
	by vger.kernel.org with ESMTP id S1751194AbWFNSDE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jun 2006 14:03:04 -0400
To: Daniel Phillips <phillips@google.com>
Content-Disposition: inline
In-Reply-To: <44904C08.6020307@google.com>; from phillips@google.com on Wed, Jun 14, 2006 at 10:48:56AM -0700
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Daniel,

On Wed, 14 Jun 2006, Daniel Phillips wrote:
> 
> Speaking as a former member of a "grey market" binary module vendor that
> came in from the cold I can assure you that the distinction between EXPORT
> and EXPORT_GPL _is_ meaningful.  That tainted flag makes it extremely
> difficult to do deals with mainstream Linux companies and there is always
> the fear that it will turn into a legal problem.  The latter bit tends to
> make venture capitalists nervous.
> 

EXPORT_SYMBOL_GPL and the Tainted flag have nothing to do with each other.

