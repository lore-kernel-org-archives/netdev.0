From: Vinay K Nallamothu <vinay.nallamothu@gsecone.com>
Subject: Re: [PATCH 2.6.0-test6][X25] timer cleanup
Date: Thu, 02 Oct 2003 12:33:28 +0530
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1065078208.4340.3.camel@lima.royalchallenge.com>
References: <1065018387.7194.336.camel@lima.royalchallenge.com>
	 <20031001155623.06b89258.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, LKML <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20031001155623.06b89258.akpm@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2003-10-02 at 04:26, Andrew Morton wrote:
> Vinay K Nallamothu <vinay.nallamothu@gsecone.com> wrote:
> >
> > Replace del_timer, mod_timer sequences with mod_timer.
> 
> was this tested?
No. But compiles fine.
