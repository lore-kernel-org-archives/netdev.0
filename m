From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] multi-protocol MSF API sysctl limit support
Date: Mon, 8 Mar 2004 12:17:48 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040308121748.687bd77f.davem@redhat.com>
References: <OF98DA688D.A9E1181F-ON88256E4F.00342F53-88256E4F.00349E68@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: David Stevens <dlstevens@us.ibm.com>
In-Reply-To: <OF98DA688D.A9E1181F-ON88256E4F.00342F53-88256E4F.00349E68@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 6 Mar 2004 02:37:56 -0700
David Stevens <dlstevens@us.ibm.com> wrote:

> This patch adds support for administrator-controlled multicast source
> filter limits for the multiprotocol multicast source filter API. The v4
> portion
> uses the same sysctl variable as the previous v4-only API patch, and
> the v6 portion uses a new v6 sysctl variable, "mld_max_msf".

Applied, thanks David.
