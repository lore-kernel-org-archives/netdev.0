From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] (2/2) Convert yam driver to seq_file
Date: Thu, 14 Aug 2003 21:22:55 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030814212255.22f27fb2.davem@redhat.com>
References: <20030813093926.7b267dd6.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jpr@f6fbb.org, jgarzik@pobox.com, linux-hams@vger.kernel.org,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20030813093926.7b267dd6.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 13 Aug 2003 09:39:26 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> Convert the yam driver to use the new seq_file interface to /proc.
> This resolves potential issues with module owner and buffer sizes
> by using the common library.

I've applied both of your YAM driver patches, thanks Stephen.
