From: "David S. Miller" <davem@redhat.com>
Subject: Re: MLDv2 MRC timer wrong units [PATCH]
Date: Tue, 18 Nov 2003 17:47:50 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031118174750.0f097ab1.davem@redhat.com>
References: <OF827DB90A.DAAAB15E-ON88256DE3.0005C3DE@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: David Stevens <dlstevens@us.ibm.com>
In-Reply-To: <OF827DB90A.DAAAB15E-ON88256DE3.0005C3DE@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 18 Nov 2003 18:19:20 -0700
David Stevens <dlstevens@us.ibm.com> wrote:

> The MLD max response code is computing in units of 1/10th second,
> as in IGMPv3, but for MLD, it should be in milliseconds. Patch below.

I will apply this, thanks David.
