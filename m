From: Patrick McHardy <kaber@trash.net>
Subject: Re: patch: introduce simple actions
Date: Sun, 20 Mar 2005 20:22:52 +0100
Message-ID: <423DCD8C.6030100@trash.net>
References: <1111345551.1095.82.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com,
        Thomas Graf <tgraf@suug.ch>
To: hadi@znyx.com
In-Reply-To: <1111345551.1095.82.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jamal Hadi Salim wrote:
> Ive posted this before - dont want it to sit here rotting. 
> If theres nothing glaringly wrong with it (Thomas/Patrick?) then Dave
> please apply so i can start shooting other patches based on it.

Any reasons why all of these need to be inline functions?
One of the next things I wanted to do in this area was
moving all the large inline functions to act_generic.c,
so if possible I would prefer not to put these in a header
file.

Regards
Patrick
