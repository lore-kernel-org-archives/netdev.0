From: "David S. Miller" <davem@redhat.com>
Subject: Re: IPSecv6/Neighbor discovery crash
Date: Thu, 21 Aug 2003 18:46:40 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030821184640.2cb89b87.davem@redhat.com>
References: <200308220149.h7M1nlAU017798@faith.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, kazunori@miyazawa.org
Return-path: <netdev-bounce@oss.sgi.com>
To: latten@austin.ibm.com
In-Reply-To: <200308220149.h7M1nlAU017798@faith.austin.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 21 Aug 2003 20:49:47 -0500
latten@austin.ibm.com wrote:

> EIP is at ndisc_build_ll_hdr+0x17/0x1e0

So what exactly is NULL in ndisc_build_ll_hdr(), is
it 'dev'?  That'd be really weird...
