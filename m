From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH V2 08/22] amd: Use pci_zalloc_consistent
Date: Tue, 24 Jun 2014 21:49:02 -0700
Message-ID: <53AA54BE.9030206@roeck-us.net>
References: <cover.1403530604.git.joe@perches.com>  <c7cdaa8e080157cdabb92278a4c3beba89b49070.1403530604.git.joe@perches.com>  <1403546524.12008.2.camel@Lunix2.home>  <1403550950.15811.15.camel@joe-AO725> <1403557507.20657.3.camel@joe-AO725>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>, Don Fry <pcnet32@frontier.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1403557507.20657.3.camel@joe-AO725>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/23/2014 02:05 PM, Joe Perches wrote:
> Remove the now unnecessary memset too.
>
> Signed-off-by: Joe Perches <joe@perches.com>
> ---
> On Mon, 2014-06-23 at 12:15 -0700, Joe Perches wrote:
>> On Mon, 2014-06-23 at 11:02 -0700, Don Fry wrote:
>>> This causes the line length to be greater than 80 characters causing
>>> checkpatch to complain.
>
> V2: Don Fry is an 80 column neatnik.
>

And you are an 'align with (' neatnik, so guess the two of you are even :-)

Guenter
