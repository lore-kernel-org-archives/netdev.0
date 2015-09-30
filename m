From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH nf-next] netfilter: Line layout whitespace fixes
Date: Thu, 1 Oct 2015 00:17:07 +0200
Message-ID: <20150930221707.GA14994@salvia>
References: <1443089406-8996-1-git-send-email-ipm@chirality.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	bridge@lists.linux-foundation.org, netdev@vger.kernel.org
To: Ian Morris <ipm@chirality.org.uk>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1443089406-8996-1-git-send-email-ipm@chirality.org.uk>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 24, 2015 at 11:10:06AM +0100, Ian Morris wrote:
> Fixes various whitespace issues detected by checkpatch (e.g. adding spaces between operations, replacing spaces with tabs, etc)
> 
> No changes detected by objdiff.

These large cleanup patch causes problems for -stable maintainers,
since they have more conflicts when backporting stuff.

I'd rather keep this back.
