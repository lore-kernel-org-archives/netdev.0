From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 2.6.10-rc1 14/15] wireless/orinoco: add minimal ethtool
 support
Date: Tue, 26 Oct 2004 15:46:04 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <417EA97C.3070303@pobox.com>
References: <1098814320.3663.24.camel@dcbw.boston.redhat.com> <1098818684.9874.1.camel@dcbw.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, jgarzik@redhat.com, hermes@gibson.dropbear.id.au
Return-path: <netdev-bounce@oss.sgi.com>
To: Dan Williams <dcbw@redhat.com>
In-Reply-To: <1098818684.9874.1.camel@dcbw.boston.redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Dan Williams wrote:
> Update in-kernel orinoco wireless drivers to upstream CVS.
> None of this is original code by Dan Williams, simply a
> broken down patch set split-out from upstream orinoco CVS.
> 
> o Add minimal ethtool support (Pavel Roskin)

should use ethtool_ops rather than manually handling the ioctl
