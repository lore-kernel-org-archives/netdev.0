From: "David S. Miller" <davem@redhat.com>
Subject: Re: O/M flags against 2.6.0-test1
Date: Fri, 25 Jul 2003 06:22:41 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030725062241.2df3e700.davem@redhat.com>
References: <200307241443.SAA09525@dub.inr.ac.ru>
	<3F20766C.3060400@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, yoshfuji@linux-ipv6.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Krishna Kumar <krkumar@us.ibm.com>
In-Reply-To: <3F20766C.3060400@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 24 Jul 2003 17:14:36 -0700
Krishna Kumar <krkumar@us.ibm.com> wrote:

> So people are ok with using struct ? Since it can be typecast as an array :-)

I think something more like route metrics, ie. an array,
is more appropriate and that Alexey is right about this.
