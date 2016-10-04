From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH v4 1/2] libxt_hashlimit: Prepare libxt_hashlimit.c for
 revision 2
Date: Tue, 4 Oct 2016 08:57:33 +0200
Message-ID: <20161004065733.GA13023@salvia>
References: <20160926190817.GA10252@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber@trash.net, kadlec@blackhole.kfki.hu, johunt@akamai.com,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org, pai.vishwain@gmail.com
To: Vishwanath Pai <vpai@akamai.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160926190817.GA10252@akamai.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 26, 2016 at 03:08:17PM -0400, Vishwanath Pai wrote:
> I am planning to add a revision 2 for the hashlimit xtables module to
> support higher packets per second rates. This patch renames all the
> functions and variables related to revision 1 by adding _v1 at the
> end of the names.

Applied, thanks.
