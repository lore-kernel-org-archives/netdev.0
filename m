From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] Add C99 initializers to net/ipv4/ipvs/ip_vs_ctl.c
Date: Tue, 16 Mar 2004 11:52:56 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040316115256.60421bb6.davem@redhat.com>
References: <20040316185229.GA12996@artsapartment.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: wensong@gnuchina.org.sgi.com, netdev@oss.sgi.com,
        linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "Art Haas" <ahaas@airmail.net>
In-Reply-To: <20040316185229.GA12996@artsapartment.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 16 Mar 2004 12:52:29 -0600
"Art Haas" <ahaas@airmail.net> wrote:

> Here is the first of three patches adding C99 initializers to
> files in net/ipv4/ipvs. This patch is for ip_vs_ctl.c, and
> is against the current BK. This patch splits a structure up
> into several variables, making the code look more like
> other files found in net/, and explicitly adds initializers
> to an existing structure.

Applied, thanks Art.
