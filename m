From: "David S. Miller" <davem@redhat.com>
Subject: Re: IGMP multicast source filter limits via sysctl [PATCH]
Date: Fri, 5 Mar 2004 14:20:22 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040305142022.3d64e5b7.davem@redhat.com>
References: <OF214E53DE.6174BA9F-ON88256E4E.001B2CE9-88256E4E.001B9715@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: David Stevens <dlstevens@us.ibm.com>
In-Reply-To: <OF214E53DE.6174BA9F-ON88256E4E.001B2CE9-88256E4E.001B9715@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 4 Mar 2004 22:04:31 -0700
David Stevens <dlstevens@us.ibm.com> wrote:

> The following patch adds a sysctl variable for administrators to set
> limits on the number of per-socket multicast source filters for IPv4.
> The in-line patch for review is for 2.4.25. Attached is the 2.4.25 version
> and the 2.6.x version.

Applied, thanks David.
