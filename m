From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: select(0, ..) is valid ?
Date: Tue, 15 May 2007 18:43:45 +0100
Message-ID: <20070515184345.0431d80e@the-village.bc.nu>
References: <1179250159.2836.117.camel@dyn9047017100.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lkml <linux-kernel@vger.kernel.org>,
	Christoph Lameter <clameter@sgi.com>,
	Andrew Morton <akpm@linux-foundation.org>
To: Badari Pulavarty <pbadari@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [81.2.110.250] ([81.2.110.250]:34527 "EHLO the-village.bc.nu"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756230AbXEORld (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 May 2007 13:41:33 -0400
In-Reply-To: <1179250159.2836.117.camel@dyn9047017100.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 15 May 2007 10:29:18 -0700
Badari Pulavarty <pbadari@us.ibm.com> wrote:

> Hi,
> 
> Is select(0, ..) is a valid operation ?

Yes. It's a fairly classic old BSD way to do timeouts

Alan
