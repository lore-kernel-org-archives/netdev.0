From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [patch net-next RFC 0/6] Introduce devlink interface and first
 drivers to use it
Date: Wed, 03 Feb 2016 16:17:14 +0100
Message-ID: <56B219FA.7080208@iogearbox.net>
References: <1454496482-13961-1-git-send-email-jiri@resnulli.us> <20160203143133.1b70bcb5@redhat.com> <20160203133356.GA2219@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, idosch@mellanox.com,
	eladr@mellanox.com, yotamg@mellanox.com, ogerlitz@mellanox.com,
	yishaih@mellanox.com, dledford@redhat.com, sean.hefty@intel.com,
	hal.rosenstock@gmail.com, eugenia@mellanox.com,
	roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	hadarh@mellanox.com, jhs@mojatatu.com, john.fastabend@gmail.com,
	jeffrey.t.kirsher@intel.com, jbenc@redhat.com
To: Jiri Pirko <jiri@resnulli.us>,
	Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:52852 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755982AbcBCPRW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2016 10:17:22 -0500
In-Reply-To: <20160203133356.GA2219@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/03/2016 02:33 PM, Jiri Pirko wrote:
> Wed, Feb 03, 2016 at 02:31:33PM CET, brouer@redhat.com wrote:
>> On Wed,  3 Feb 2016 11:47:56 +0100
>> Jiri Pirko <jiri@resnulli.us> wrote:
>>> From: Jiri Pirko <jiri@mellanox.com>
[...]
>>> It is available here:
>>> https://github.com/jpirko/devlink
>>
>> IHMO this very short command name "dl" is not an advantage.  It is
>> simply too unspecific and short for a good Google search.  E.g. when
>> searching for good examples for using "dl".  I think "devlink" would be
>> better.  If you like short commands do: alias dl="devlink"
>
> I was thinking about using "devlink". Decided to go with shortened
> version so this is in-line with "ip". But you have a point.

Btw, if you add this tool into iproute2 (which would be preferred), then
probably dl should be ok (and easier retrievable in that relation).
