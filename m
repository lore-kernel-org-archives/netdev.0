From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [0/3] Distributed storage. Mirror algo extension for automatic
 recovery.
Date: Fri, 26 Oct 2007 13:55:38 -0700
Message-ID: <20071026135538.d22125a2.akpm@linux-foundation.org>
References: <20071018191741.GA848@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20071018191741.GA848@2ka.mipt.ru>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 18 Oct 2007 23:17:41 +0400
Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote:

> I'm pleased to announce sixth release of the distributed storage
> subsystem, which allows to form a storage on top of remote and local
> nodes, which in turn can be exported to another storage as a node to
> form tree-like storages.

I went back and re-read last month's discussion and I'm not seeing any
reason why we shouldn't start thinking about merging this.

How close is it to that stage?  A peek at your development blog indicates
that things are still changing at a moderate rate?

