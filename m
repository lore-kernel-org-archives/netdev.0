From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH 2.6.10-rc1 1/15] wireless/orinoco: Use msleep() instead
	of hardcoded schedule_timeout()s
Date: Tue, 26 Oct 2004 15:35:36 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1098819336.9874.11.camel@dcbw.boston.redhat.com>
References: <1098814320.3663.24.camel@dcbw.boston.redhat.com>
	 <1098815604.3663.35.camel@dcbw.boston.redhat.com>
	 <20041026184749.GA16621@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, jgarzik@redhat.com, hermes@gibson.dropbear.id.au
Return-path: <netdev-bounce@oss.sgi.com>
To: Christoph Hellwig <hch@infradead.org>
In-Reply-To: <20041026184749.GA16621@infradead.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

New description:

o Use msleep() instead of hardcoded schedule_timeout()s
o Normalize sleep calls to use msleep() everywhere

Dan
