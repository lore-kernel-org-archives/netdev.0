From: Giacomo Catenazzi <cate@debian.org>
Subject: Re: last git: BUG: unable to handle kernel paging request at virtual
 address 92184900
Date: Mon, 29 Oct 2007 18:35:58 +0100
Message-ID: <472619FE.80309@debian.org>
References: <471E45B4.9050504@debian.org> <20071029011148.76ae8dd4.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759507AbXJ2RgY@vger.kernel.org>
In-Reply-To: <20071029011148.76ae8dd4.akpm@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Morton wrote:
> On Tue, 23 Oct 2007 21:04:20 +0200 Giacomo Catenazzi <cate@debian.org> wrote:
> 
>> Oct 23 20:20:05 catee kernel: BUG: unable to handle kernel paging request at virtual address 92184900
> 
> Is this still happening in the latest Linus tree?
> 
> If so, please send some more oops traces so we can see if it's always happening
> in the same place.

No, since few days I didn't have kernel crashes, so I think the
bug was solved.

ciao
	cate
