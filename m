From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] [IPv6][IPsec] fix oops with using IPsec
Date: Fri, 24 Oct 2003 05:37:01 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031024053701.4155945f.davem@redhat.com>
References: <20031024213058.47b4a824.kazunori@miyazawa.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, usagi@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Kazunori Miyazawa <kazunori@miyazawa.org>
In-Reply-To: <20031024213058.47b4a824.kazunori@miyazawa.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 24 Oct 2003 21:30:58 +0900
Kazunori Miyazawa <kazunori@miyazawa.org> wrote:

> This patch fixes oops with using IPsec in IPv6. Original source removes
> RTF_NDISC at copying dst. It makes the kernel use the wrong stackable
> destination.

Patch applied, thank you very much.
