From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH 2.6.0-test6][X25] timer cleanup
Date: Tue, 7 Oct 2003 07:48:33 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031007074833.6bb5a6e1.davem@redhat.com>
References: <1065018387.7194.336.camel@lima.royalchallenge.com>
	<20031001155623.06b89258.akpm@osdl.org>
	<1065078208.4340.3.camel@lima.royalchallenge.com>
	<20031002013620.6d8b6f10.davem@redhat.com>
	<1065362979.4370.34.camel@lima.royalchallenge.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Vinay K Nallamothu <vinay.nallamothu@gsecone.com>
In-Reply-To: <1065362979.4370.34.camel@lima.royalchallenge.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 05 Oct 2003 19:39:39 +0530
Vinay K Nallamothu <vinay.nallamothu@gsecone.com> wrote:

> On Thu, 2003-10-02 at 14:06, David S. Miller wrote:
> > Please find a way to at least minimally test the protocols
> > you are changing then, or find someone else who can.
>
> I have tested the patch using LAPB over Ethernet (I do not have real
> hardware) under linux-2.6.0-test5-uml1 and it works fine for me.

Fair enough, I've applied this patch, thanks a lot Vinay.
