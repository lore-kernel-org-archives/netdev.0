From: "David S. Miller" <davem@redhat.com>
Subject: Re: sungem - ifconfig eth0 mtu 1300 -> oops
Date: Tue, 22 Jun 2004 12:35:23 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040622123523.28fca55a.davem@redhat.com>
References: <20040621141144.119be627.davem@redhat.com>
	<40D847E3.2080109@nortelnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, kernel@nn7.de, linux-kernel@vger.kernel.org,
        benh@kernel.crashing.org, netdev@oss.sgi.com, jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Chris Friesen <cfriesen@nortelnetworks.com>
In-Reply-To: <40D847E3.2080109@nortelnetworks.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 22 Jun 2004 10:53:23 -0400
Chris Friesen <cfriesen@nortelnetworks.com> wrote:

> Just a quick question.  Does the sungem chip support jumbo frames?

Nope, not at all.
