From: "David S. Miller" <davem@redhat.com>
Subject: Re: MLDv1 bug [PATCH]
Date: Thu, 20 Nov 2003 15:49:54 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031120154954.004b5713.davem@redhat.com>
References: <OF57EBC173.5A7DDA2A-ON88256DE4.007B48CB@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: David Stevens <dlstevens@us.ibm.com>
In-Reply-To: <OF57EBC173.5A7DDA2A-ON88256DE4.007B48CB@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 20 Nov 2003 15:33:52 -0700
David Stevens <dlstevens@us.ibm.com> wrote:

>       The current MLDv1 code does not send reports for link-scope addresses
> and doesn't restrict scope 0. This may break switches that snoop reports for
> determining which ports should receive particular addresses.  Patch below.

I'll apply this, thanks David.
