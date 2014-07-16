From: Christoph Schulz <develop@kristov.de>
Subject: Re: [PATCH net-next 1/1] net: ppp: reset nextseq counter when
 enabling SC_MULTILINK
Date: Wed, 16 Jul 2014 23:48:51 +0200
Message-ID: <20140716234851.95825g9vvaydvbyb@berry.schulz.ip-v6.eu>
References: <20140715.225259.1933230941203001162.davem@davemloft.net>
 <20140716231950.17744ie9e3i9ea9i@berry.schulz.ip-v6.eu>
 <20140716232443.872830586nfymtnf@berry.schulz.ip-v6.eu>
 <20140716.142754.647038534547707816.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8;
 DelSp="Yes";
 format="flowed"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-ppp@vger.kernel.org, paulus@samba.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-ppp-owner@vger.kernel.org>
In-Reply-To: <20140716.142754.647038534547707816.davem@davemloft.net>
Content-Disposition: inline
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

David Miller schrieb am Wed, 16 Jul 2014 14:27:54 -0700 (PDT):

>> Sorry, how should I do it? Based on the *current* state of net-next,
>> i.e. based on my original (but incomplete) patch? Or based on the
>> net-next tree before my original patch was included?
>
> Based upon the current state of net-next, you're sending me a bug
> fix for the change you made.

Thank you for the clarification. I just sent the bugfix patch to the  
mailing list. Sorry for my first erroneous patch -- I have never  
tested the patch without CONFIG_PPP_MULTILINK being defined. At least  
I learned something for the future...


Regards,

Christoph Schulz

