From: "David S. Miller" <davem@redhat.com>
Subject: Re: [patch] e1000 TSO parameter
Date: Mon, 14 Jul 2003 21:45:10 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030714214510.17e02a9f.davem@redhat.com>
References: <C6F5CF431189FA4CBAEC9E7DD5441E0102229169@orsmsx402.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davidm@hpl.hp.com, linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Feldman, Scott" <scott.feldman@intel.com>
In-Reply-To: <C6F5CF431189FA4CBAEC9E7DD5441E0102229169@orsmsx402.jf.intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 14 Jul 2003 21:42:40 -0700
"Feldman, Scott" <scott.feldman@intel.com> wrote:

> > Note that I had to move the e1000_check_options() call to a 
> > slighly earlier place.  You may want to double-check that 
> > it's really OK.
> 
> I'm not too keen on adding another module parameter.  Maybe a
> CONFIG_E1000_TSO option?

Extend ethtool please :-)
