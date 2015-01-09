From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 2/6] vxlan: Group Policy extension
Date: Fri, 9 Jan 2015 22:10:42 +0000
Message-ID: <20150109221042.GB20711@casper.infradead.org>
References: <cover.1420756324.git.tgraf@suug.ch>
 <7339e3bff124cecaf65cd04ea9bdc973c730ba34.1420756324.git.tgraf@suug.ch>
 <CAADnVQKUNc4pu7W6Riies3tVeh848ihHidb3iM2UnbEmea-Y-Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Jesse Gross <jesse@nicira.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Pravin Shelar <pshelar@nicira.com>,
	Tom Herbert <therbert@google.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:56454 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751713AbbAIWKo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2015 17:10:44 -0500
Content-Disposition: inline
In-Reply-To: <CAADnVQKUNc4pu7W6Riies3tVeh848ihHidb3iM2UnbEmea-Y-Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/09/15 at 09:37am, Alexei Starovoitov wrote:
> On Thu, Jan 8, 2015 at 2:47 PM, Thomas Graf <tgraf@suug.ch> wrote:
> > +
> > +struct vxlan_gbp {
> > +} __packed;
> 
> empty struct ? seems unused.
> looks good to me otherwise.

Poor leftover, must feel all lonely there. Thanks for the reviews.
Will wait a little bit longer for more feedback and send out v3.
