From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [RFC PATCH net-next 0/3] Allow bridge to function in
	non-promisc mode
Date: Wed, 6 Mar 2013 23:19:14 -0800
Message-ID: <CAOaVG17iZu3r9no5FtNU-6ZwW2UdR3QBE6O3EKm6-JXAmEyuyA@mail.gmail.com>
References: <1362623485-18209-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/alternative; boundary=20cf307f38102422f104d750860b
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org
To: vyasevic@redhat.com
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1362623485-18209-1-git-send-email-vyasevic@redhat.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

--20cf307f38102422f104d750860b
Content-Type: text/plain; charset=ISO-8859-1

I understand the desire to add more functionality, but in this case it
would introduce lots more problems. STP would break and it doesn't seem to
gain anything that can't be done by other means.

Turning bridge into macvlan seems unnecessary. Combining apples and bananas
doesn't always make a tasty smoothy, sometimes it is just a mess.

Maybe adding a little more to macvlan to do what you want would be simpler.

--20cf307f38102422f104d750860b
Content-Type: text/html; charset=ISO-8859-1

<p dir="ltr">I understand the desire to add more functionality, but in this case it would introduce lots more problems. STP would break and it doesn&#39;t seem to gain anything that can&#39;t be done by other means.</p>
<p dir="ltr">Turning bridge into macvlan seems unnecessary. Combining apples and bananas doesn&#39;t always make a tasty smoothy, sometimes it is just a mess.</p>
<p dir="ltr">Maybe adding a little more to macvlan to do what you want would be simpler.</p>

--20cf307f38102422f104d750860b--
