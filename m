From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC] IPSEC failover and replay detection sequence numbers
Date: 29 Oct 2004 08:58:41 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1099054721.1027.118.camel@jzny.localdomain>
References: <1099045435.2888.47.camel@nienna.balabit>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, ipsec-tools-devel@lists.sourceforge.net,
        vpn-failover@lists.balabit.hu
Return-path: <netdev-bounce@oss.sgi.com>
To: KOVACS Krisztian <hidden@balabit.hu>
In-Reply-To: <1099045435.2888.47.camel@nienna.balabit>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Krisztian,

To take a rough estimate of 5K users, how often do you think
these replay messages will be generated?

Is there a (clever) way to avoid transporting them and still achieve
an accurate failover?

cheers,
jamal
