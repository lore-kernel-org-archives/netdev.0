From: =?UTF-8?B?UGF3ZcWCIFN0YXN6ZXdza2k=?= <pstaszewski@itcare.pl>
Subject: Re: [ SPAM ] Re: Is this normal?
Date: Wed, 28 Jan 2009 17:09:35 +0100
Message-ID: <4980833F.40301@itcare.pl>
References: <497F14B1.7070306@itcare.pl> <497F16F7.6020504@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Network Development list <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <497F16F7.6020504@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

after patch i have:

CPU: Core 2, speed 3000 MHz (estimated)
Counted CPU_CLK_UNHALTED events (Clock cycles when not halted) with a=20
unit mask of 0x00 (Unhalted core cycles) count 100000
samples  %        image name               app name                =20
symbol name
767616   13.0507  vmlinux                  vmlinux                 =20
u32_delete
291303    4.9526  vmlinux                  vmlinux                 =20
_raw_spin_trylock
269856    4.5880  vmlinux                  vmlinux                 =20
do_ipt_get_ctl
221887    3.7724  vmlinux                  vmlinux                 =20
devm_ioport_unmap
202405    3.4412  vmlinux                  vmlinux                 =20
devm_ioport_map
150375    2.5566  vmlinux                  vmlinux                 =20
native_calibrate_tsc
138476    2.3543  vmlinux                  vmlinux                 =20
update_persistent_clock
103328    1.7567  vmlinux                  vmlinux                 =20
update_wall_time
101648    1.7282  vmlinux                  vmlinux                 =20
e1000_xmit_frame
100776    1.7134  vmlinux                  vmlinux                 =20
__ip_route_output_key
94866     1.6129  vmlinux                  vmlinux                 =20
dev_ethtool
88844     1.5105  vmlinux                  vmlinux                 =20
dev_queue_xmit
88582     1.5060  vmlinux                  vmlinux                 =20
ixgbe_update_rx_dca
87747     1.4918  vmlinux                  vmlinux                 =20
__pskb_pull_tail
86888     1.4772  vmlinux                  vmlinux                 =20
irq_entries_start
77941     1.3251  vmlinux                  vmlinux                 =20
ixgbe_configure
76646     1.3031  vmlinux                  vmlinux                 =20
ixgbe_clean_rx_irq
75933     1.2910  vmlinux                  vmlinux                 =20
ixgbe_alloc_rx_buffers
75538     1.2843  vmlinux                  vmlinux                 =20
e1000_get_eeprom
75380     1.2816  vmlinux                  vmlinux                 =20
ixgbe_vlan_rx_kill_vid
71534     1.2162  vmlinux                  vmlinux                 =20
e1000e_update_stats
70017     1.1904  vmlinux                  vmlinux                 =20
ip_route_input
67435     1.1465  vmlinux                  vmlinux                  udp=
_mt
66901     1.1374  vmlinux                  vmlinux                 =20
mach_set_rtc_mmss
65824     1.1191  vmlinux                  vmlinux                 =20
htb_dequeue
63405     1.0780  vmlinux                  vmlinux                 =20
text_poke
58282     0.9909  vmlinux                  vmlinux                 =20
devm_ioremap
57893     0.9843  vmlinux                  vmlinux                 =20
e1000_open
51794     0.8806  vmlinux                  vmlinux                 =20
ctrl_dumpfamily
49911     0.8486  vmlinux                  vmlinux                 =20
dev_seq_show
49514     0.8418  vmlinux                  vmlinux                 =20
skb_copy_and_csum_bits
49168     0.8359  vmlinux                  vmlinux                 =20
e1000_clean_rx_irq_ps
48879     0.8310  vmlinux                  vmlinux                 =20
ixgbe_setup_dca
45064     0.7662  vmlinux                  vmlinux                 =20
dev_unicast_sync
43600     0.7413  vmlinux                  vmlinux                 =20
ixgbe_clean_tx_irq
42552     0.7235  vmlinux                  vmlinux                 =20
ixgbe_xmit_frame
41313     0.7024  vmlinux                  vmlinux                 =20
_format_mac_addr
41011     0.6973  vmlinux                  vmlinux                 =20
pcim_iomap_regions
40975     0.6966  vmlinux                  vmlinux                  sfq=
_init
38783     0.6594  vmlinux                  vmlinux                 =20
tc_ctl_action
35913     0.6106  vmlinux                  vmlinux                 =20
hfsc_reset_qdisc
34672     0.5895  vmlinux                  vmlinux                 =20
xt_check_match
32446     0.5516  vmlinux                  vmlinux                 =20
packet_rcv
31861     0.5417  vmlinux                  vmlinux                 =20
__lru_cache_add
31555     0.5365  vmlinux                  vmlinux                  s_s=
top
30430     0.5174  vmlinux                  vmlinux                 =20
ip_defrag
30235     0.5140  vmlinux                  vmlinux                 =20
rwlock_bug
29314     0.4984  vmlinux                  vmlinux                  htb=
_init
29236     0.4971  vmlinux                  vmlinux                 =20
net_tx_action
29062     0.4941  vmlinux                  vmlinux                 =20
apply_alternatives
28241     0.4801  vmlinux                  vmlinux                 =20
tick_nohz_restart_sched_tick
27626     0.4697  vmlinux                  vmlinux                 =20
do_sysinfo
25705     0.4370  vmlinux                  vmlinux                 =20
htb_delete
25336     0.4308  vmlinux                  vmlinux                 =20
e1000_clean_jumbo_rx_irq
24546     0.4173  vmlinux                  vmlinux                 =20
tick_init_jiffy_update
22883     0.3890  vmlinux                  vmlinux                 =20
ixgbe_init_interrupt_scheme

Patrick McHardy pisze:
> Pawe=C5=82 Staszewski wrote:
>> I have Linux that works as Router + traffic management with=20
>> connection tracking enabled but without making NAT
>>
>> About 600Mbit/s TX and 600Mbit/s RX forwarded traffic
>>
>> iptables -L -n -v -t raw
>> Chain PREROUTING (policy ACCEPT 3340M packets, 2623G bytes)
>> pkts bytes target     prot opt in     out     source              =20
>> destination
>> 3339M 2621G NOTRACK    all  --  *      *       0.0.0.0/0           =20
>> 0.0.0.0/0
>>
>>
>> kernel 2.6.28.2
>> CPU: Core 2, speed 2999.98 MHz (estimated)
>> Counted CPU_CLK_UNHALTED events (Clock cycles when not halted) with =
a=20
>> unit mask of 0x00 (Unhalted core cycles) count 100000
>> samples  %        image name               app name                =20
>> symbol name
>> 14544205 15.8604  vmlinux                  vmlinux                 =20
>> ctnetlink_del_expect
>
> This doesn't seem to be accurate, I'm guessing its really
> ctnetlink_conntrack_event().
>
> Does this patch make any difference?

--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
