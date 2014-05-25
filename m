From: David Miller <davem@davemloft.net>
Subject: Re: Revert 462fb2af9788a82a534f8184abfde31574e1cfa0
 (bridge : Sanitize skb before it enters the IP stack)
Date: Sat, 24 May 2014 23:02:02 -0400 (EDT)
Message-ID: <20140524.230202.372276424258120234.davem@davemloft.net>
References: <53803488.6000400@davidnewall.com>
	<20140524.134356.992924324126016022.davem@davemloft.net>
	<53815623.8020506@davidnewall.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bdschuym@pandora.be, netdev@vger.kernel.org, vyasevich@gmail.com,
	bridge@lists.linux-foundation.org, fw@strlen.de,
	stephen@networkplumber.org, bsd@redhat.com, netfilter-devel@vger.kernel.org
To: davidn@davidnewall.com
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <53815623.8020506@davidnewall.com>
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

From: David Newall <davidn@davidnewall.com>
Date: Sun, 25 May 2014 12:02:03 +0930

> On 25/05/14 03:13, David Miller wrote:
>> This patch was substantially corrupted by your email client.
> 
> We should be sending these things as mime attachments.  Having to put
> patches inline is brittle, absurd and a waste of everyone's time.  Is
> there actually anybody here who doesn't have a mime-compatible MUA?

It makes replying and commenting inline easy.

It's not our problem that so many email clients make sending
plain unmolested ASCII text difficult.  But at least we've gone
out of our way to document how to do so in the kernel tree.
