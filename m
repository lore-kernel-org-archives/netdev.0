From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: pull request: wireless-2.6 2008-10-29
Date: Wed, 29 Oct 2008 21:00:05 -0700
Message-ID: <20081029210005.48e4765f@infradead.org>
References: <20081029231855.GD3485@tuxdriver.com>
	<20081029162324.28f5864d@infradead.org>
	<20081029233350.GE3485@tuxdriver.com>
	<b6c5339f0810291819ld7d6043k56b11128bc6252cb@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>, davem@davemloft.net,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, mcgrof@gmail.com, mickflemm@gmail.com
To: "Bob Copeland" <me@bobcopeland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:53038 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750756AbYJ3D7r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2008 23:59:47 -0400
In-Reply-To: <b6c5339f0810291819ld7d6043k56b11128bc6252cb@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 29 Oct 2008 21:19:01 -0400
"Bob Copeland" <me@bobcopeland.com> wrote:

> On Wed, Oct 29, 2008 at 7:33 PM, John W. Linville
> <linville@tuxdriver.com> wrote:
> > On Wed, Oct 29, 2008 at 04:23:24PM -0700, Arjan van de Ven wrote:
> >> On Wed, 29 Oct 2008 19:18:55 -0400
> >> "John W. Linville" <linville@tuxdriver.com> wrote:
> >> it seems to have added a few WARN_ON()s which now end up at the
> >> top of the list .. are these known or should I spend some time
> >> writing reports for netdev ?
> 
> Pavel Roskin posted one such WARN_ON to ath5k-devel a few days ago.
> Seems related to setup of the rate tables, but I haven't reproduced it
> here yet.  I'll see if he has more info...

if there's things that would help you diagnose such issue let me know
(always trying to make kerneloops.org more useful for developers ;-)

> 


-- 
Arjan van de Ven 	Intel Open Source Technology Centre
For development, discussion and tips for power savings, 
visit http://www.lesswatts.org
