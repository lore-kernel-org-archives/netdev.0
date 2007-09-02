From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH -mm] net/sched/sch_cbq.c: Shut up uninitialized variable
 warning
Date: Sun, 02 Sep 2007 13:36:40 +0200
Message-ID: <46DAA048.3090709@trash.net>
References: <20070831215822.26e1432b.akpm@linux-foundation.org> <alpine.LFD.0.999.0709020656050.20781@enigma.security.iitk.ac.in>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Satyam Sharma <satyam@infradead.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S965594AbXIBLi3@vger.kernel.org>
In-Reply-To: <alpine.LFD.0.999.0709020656050.20781@enigma.security.iitk.ac.in>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Satyam Sharma wrote:
> net/sched/sch_cbq.c: In function 'cbq_enqueue':
> net/sched/sch_cbq.c:383: warning: 'ret' may be used uninitialized in this function
>
> has been verified to be a bogus case. So let's shut it up.
>
> Signed-off-by: Satyam Sharma <satyam@infradead.org>

Acked-by: Patrick McHardy <kaber@trash.net>
