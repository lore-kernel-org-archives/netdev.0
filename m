From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH 2.6.5] bridge - replace CLEAR_BITMAP with memset
Date: Fri, 16 Apr 2004 14:24:15 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040416142415.07572f56.davem@redhat.com>
References: <20040413151630.710042e3@dell_ss3.pdx.osdl.net>
	<20040414120434.2029b567@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bridge@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040414120434.2029b567@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 14 Apr 2004 12:04:34 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> It looks like a recent patch to 2.6.5 got rid of CLEAR_BITMAP.

Applied.
