From: "Chris Leech" <chris.leech@gmail.com>
Subject: Re: [PATCH 0/8] Intel I/O Acceleration Technology (I/OAT)
Date: Fri, 3 Mar 2006 15:32:29 -0800
Message-ID: <41b516cb0603031532n517f78efh932d452648574d2@mail.gmail.com>
References: <20060303214036.11908.10499.stgit@gitlost.site>
	 <54FF0817-23ED-47F1-8234-FD3079B3E403@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932593AbWCCXch@vger.kernel.org>
To: "Kumar Gala" <galak@kernel.crashing.org>
In-Reply-To: <54FF0817-23ED-47F1-8234-FD3079B3E403@kernel.crashing.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 3/3/06, Kumar Gala <galak@kernel.crashing.org> wrote:
>
> How does this relate to Dan William's ADMA work?

I only became aware of Dan's ADMA work when he posted it last month,
and so far have not made any attempts to merge the I/OAT code with it.
 Moving forward, combining these interfaces certainly seems like the
right way to go.  I particularly like ADMA's handling of operations
other than just a copy (memset, compare, XOR, CRC).

Chris
