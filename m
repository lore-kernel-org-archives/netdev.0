From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH][IPV6] fix clearing in ah6 input
Date: Thu, 7 Aug 2003 21:47:32 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030807214732.1d16cc94.davem@redhat.com>
References: <20030806162808.4edf9eeb.kazunori@miyazawa.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com, usagi@linux-ipv6.org,
   latten@austin.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Kazunori Miyazawa <kazunori@miyazawa.org>
In-Reply-To: <20030806162808.4edf9eeb.kazunori@miyazawa.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 6 Aug 2003 16:28:08 +0900
Kazunori Miyazawa <kazunori@miyazawa.org> wrote:

> This patch fixes zero-clear in ah6_input.
> If calling pskb_expand_head, the kernel clears wrong memory.

Patch applied, thank you very much.
