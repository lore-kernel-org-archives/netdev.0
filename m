From: "John S. Denker" <jsd@monmouth.com>
Subject: ?completeness of IPsec feature-set
Date: Thu, 27 Mar 2003 06:13:59 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3E82DCF7.7090706@monmouth.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi --

I've been unable to find much discussion of what IPsec
features should be built into 2.5 / 2.6 to ensure a
reasonable level of usability and scalability.

For example, consider the challenge of establishing an
ordinary VPN where N-1 of the gateways have changeable
wild-side IP addresses.  AFAICT nobody knows how to get
racoon to do this.

People were hoping that the new IPsec implementation
would be a step forward.  If it can't support road
warriors it might be considered a step backwards.

Mr. Atkins recently offered to look into the road-warrior
issue in particular ...
http://lists.freeswan.org/pipermail/design/2003-March/004575.html

... but the overall question remains:  What has been
done to ensure completeness and coherence of the
design in general?

Is there a document somewhere listing the set of
desirable features and the status thereof?  If not,
it's high time to create one.

If you want to know what sort of features I'm talking
about, please see
http://www.monmouth.com/~jsd/vpn/ipsec+routing/feature-list.htm

Some of the listed features are obvious and already implemented
or at least promised.  But others may be less obvious and their
status is not clear.
