From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] bridge: fix message_age_timer calculation
Date: Wed, 11 Sep 2013 16:48:32 -0400 (EDT)
Message-ID: <20130911.164832.448084143075884864.davem@davemloft.net>
References: <1378745768-4495-1-git-send-email-cphealy@gmail.com>
	<5230B93B.3040900@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org, buytenh@wantstofly.org
To: sergei.shtylyov@cogentembedded.com
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <5230B93B.3040900@cogentembedded.com>
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

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Wed, 11 Sep 2013 22:40:59 +0400

> Hello.
> 
> On 09/09/2013 08:56 PM, Chris Healy wrote:
> 
>> This changes the message_age_timer calculation to use the BPDU's max
>> age as opposed to the local bridge's max age.  This is in accordance
>> with section 8.6.2.3.2 Step 2 of the 802.1D-1998 sprecification.
> 
>    You should wrap your changelog lines at 80 chars at most, preferably
>    less.

Yes, please fix this and resubmit.
