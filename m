From: Phil Oester <kernel@linuxace.com>
Subject: Re: 2.6.25-rc: Null dereference in ip_defrag
Date: Wed, 19 Mar 2008 17:39:17 -0700
Message-ID: <20080320003917.GA9198@linuxace.com>
References: <20080317170008.GA30338@linuxace.com> <47DEACF7.10202@openvz.org> <47DEADC4.4010609@trash.net> <20080317194014.GA7302@linuxace.com> <47DF7511.5080502@openvz.org> <47DF9099.30701@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from adsl-67-120-171-161.dsl.lsan03.pacbell.net ([67.120.171.161]:59013
	"HELO linuxace.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S933799AbYCTAjS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Mar 2008 20:39:18 -0400
Content-Disposition: inline
In-Reply-To: <47DF9099.30701@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 18, 2008 at 12:51:21PM +0300, Pavel Emelyanov wrote:
> >> I can try either patch, but Patrick's looks simpler and thus perhaps
> >> a better candidate this late in the -rc stage.
> >>
> >> Pavel - you concur?
> 
> Phil, I agree with Patrick's patch.

And it has survived 1.5 days without issue.  Patrick - will you be pushing
to David?

Phil
