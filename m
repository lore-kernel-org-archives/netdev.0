From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] Convert hp100 to useing alloc_etherdev
Date: Wed, 9 Jul 2003 14:45:29 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030709144529.5c14d995.shemminger@osdl.org>
References: <20030708151427.328aae38.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <20030708151427.328aae38.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This patch won't work for the non-module probe case, will resubmit a better one.
